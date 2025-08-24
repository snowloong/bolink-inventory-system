import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('系统管理')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  @ApiOperation({ summary: '系统健康检查', description: '检查系统运行状态' })
  @ApiResponse({ status: 200, description: '系统正常运行' })
  getHello(): string {
    return this.appService.getHello();
  }
}
