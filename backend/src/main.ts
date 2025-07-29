import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import * as helmet from 'helmet';
import * as compression from 'compression';
import * as cors from 'cors';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 全局管道
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // 安全中间件
  app.use(helmet());
  app.use(compression());
  app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true,
  }));

  // API前缀
  app.setGlobalPrefix('api/v1');

  // Swagger文档配置
  const config = new DocumentBuilder()
    .setTitle('博链科技进销存管理系统API')
    .setDescription('新能源电池进销存信息管理系统后端API文档')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 博链科技进销存管理系统后端服务已启动`);
  console.log(`📖 API文档: http://localhost:${port}/api/docs`);
  console.log(`🌐 服务地址: http://localhost:${port}`);
}

bootstrap(); 