import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from '../entities/user.entity';
import { LoginDto, RegisterDto, ChangePasswordDto } from '../dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async validateUser(username: string, password: string): Promise<any> {
    const user = await this.userRepository.findOne({
      where: [
        { username },
        { email: username },
      ],
    });

    if (user && await user.validatePassword(password)) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.username, loginDto.password);
    
    if (!user) {
      throw new UnauthorizedException('用户名或密码错误');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('账户已被禁用');
    }

    // 更新最后登录时间
    await this.userRepository.update(user.id, { lastLoginAt: new Date() });

    const payload = { 
      username: user.username, 
      sub: user.id,
      role: user.role,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
      },
    };
  }

  async register(registerDto: RegisterDto) {
    // 检查用户名和邮箱是否已存在
    const existingUser = await this.userRepository.findOne({
      where: [
        { username: registerDto.username },
        { email: registerDto.email },
      ],
    });

    if (existingUser) {
      throw new BadRequestException('用户名或邮箱已存在');
    }

    const user = this.userRepository.create({
      ...registerDto,
      role: registerDto.role as UserRole || UserRole.OPERATOR,
    });

    const savedUser = await this.userRepository.save(user);
    const { password, ...result } = savedUser;
    
    return result;
  }

  async changePassword(userId: number, changePasswordDto: ChangePasswordDto) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    
    if (!user) {
      throw new UnauthorizedException('用户不存在');
    }

    const isValidPassword = await user.validatePassword(changePasswordDto.currentPassword);
    
    if (!isValidPassword) {
      throw new BadRequestException('当前密码错误');
    }

    user.password = changePasswordDto.newPassword;
    await this.userRepository.save(user);

    return { message: '密码修改成功' };
  }

  async getProfile(userId: number) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    
    if (!user) {
      throw new UnauthorizedException('用户不存在');
    }

    const { password, ...result } = user;
    return result;
  }
} 