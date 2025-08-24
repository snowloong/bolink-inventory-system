import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { BasicDataController } from './basic-data.controller';

@Module({
  imports: [],
  controllers: [AppController, BasicDataController],
  providers: [AppService],
})
export class AppModule { }
