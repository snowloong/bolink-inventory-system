import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ description: '用户名或邮箱' })
  @IsString()
  username: string;

  @ApiProperty({ description: '密码' })
  @IsString()
  @MinLength(6)
  password: string;
}

export class RegisterDto {
  @ApiProperty({ description: '用户名' })
  @IsString()
  username: string;

  @ApiProperty({ description: '邮箱' })
  @IsEmail()
  email: string;

  @ApiProperty({ description: '密码' })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ description: '名字' })
  @IsString()
  firstName: string;

  @ApiProperty({ description: '姓氏' })
  @IsString()
  lastName: string;

  @ApiProperty({ description: '角色', required: false })
  @IsOptional()
  @IsString()
  role?: string;
}

export class ChangePasswordDto {
  @ApiProperty({ description: '当前密码' })
  @IsString()
  currentPassword: string;

  @ApiProperty({ description: '新密码' })
  @IsString()
  @MinLength(6)
  newPassword: string;
} 