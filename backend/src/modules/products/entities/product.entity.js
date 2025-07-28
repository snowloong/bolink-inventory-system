const { EntitySchema } = require('typeorm');

const Product = new EntitySchema({
  name: 'Product',
  tableName: 'products',
  columns: {
    id: {
      primary: true,
      type: 'int',
      generated: true,
    },
    name: {
      type: 'varchar',
      length: 100,
      unique: true,
    },
    code: {
      type: 'varchar',
      length: 50,
      unique: true,
    },
    description: {
      type: 'text',
      nullable: true,
    },
    price: {
      type: 'decimal',
      precision: 10,
      scale: 2,
    },
    unit: {
      type: 'varchar',
      length: 20,
    },
    minStock: {
      type: 'int',
      default: 0,
    },
    maxStock: {
      type: 'int',
      default: 0,
    },
    status: {
      type: 'varchar',
      length: 20,
      default: 'ACTIVE',
    },
    createdAt: {
      type: 'timestamp',
      createDate: true,
    },
    updatedAt: {
      type: 'timestamp',
      updateDate: true,
    },
  },
});

module.exports = { Product };

// TODO: 添加关联关系
// TODO: 添加索引
// TODO: 添加验证 