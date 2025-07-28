/*** 
 * @Author: yaoruidong yaord@meix.com
 * @Date: 2025-07-28 23:56:54
 * @LastEditors: yaoruidong yaord@meix.com
 * @LastEditTime: 2025-07-28 23:57:14
 * @FilePath: /bolink-inventory-system/backend/src/main.js
 * @Description: 
 * @
 */
const { NestFactory } = require('@nestjs/core');
const { ValidationPipe } = require('@nestjs/common');
const { SwaggerModule, DocumentBuilder } = require('@nestjs/swagger');
const { AppModule } = require('./app.module');

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 全局验证管道
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // CORS配置
  app.enableCors({
    origin: ['http://localhost:3000', 'http://localhost:1420'],
    credentials: true,
  });

  // Swagger API文档配置
  const config = new DocumentBuilder()
    .setTitle('博链科技进销存管理系统API')
    .setDescription('新能源电池进销存管理系统后端API文档')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 应用已启动，端口: ${port}`);
  console.log(`📚 API文档: http://localhost:${port}/api`);
}

bootstrap();

// TODO: 配置环境变量
// TODO: 配置日志系统
// TODO: 配置错误处理 