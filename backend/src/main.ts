import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 配置Swagger文档
  const config = new DocumentBuilder()
    .setTitle('新能源电池进销存信息管理系统')
    .setDescription('专为产业链中间环节设计的企业级新能源电池进销存管理系统API文档')
    .setVersion('1.0')
    .addTag('基础数据管理', '产品、供应商、客户、仓库管理')
    .addTag('采购管理', '采购计划、订单、验收管理')
    .addTag('库存管理', '库存监控、批次、库位管理')
    .addTag('销售管理', '销售订单、出库、客户管理')
    .addTag('质量控制', '质量检验、追溯、不合格品处理')
    .addTag('安全管理', '仓储安全、运输安全、应急管理')
    .addTag('报表统计', '进销存报表、分析统计')
    .addTag('系统管理', '用户权限、配置、备份管理')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
    customSiteTitle: '新能源电池进销存系统API文档',
  });

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
