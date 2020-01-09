import path from 'path';
import sequelize from 'sequelize';

const db = {};
const env = process.env.NODE_ENV || 'development';
const sequelizeConfig = require(`${__dirname}/../../config.js`)[env];

const ORM = new sequelize(
  sequelizeConfig.database,
  sequelizeConfig.username,
  sequelizeConfig.password,
  sequelizeConfig
);

db.Action = ORM.import(path.join(__dirname, 'action.js'));
db.LifeSituation = ORM.import(path.join(__dirname, 'life_situation.js'));
db.PaymentType = ORM.import(path.join(__dirname, 'payment_type.js'));

Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

db.ORM = ORM;
db.sequelize = sequelize;

module.exports = db;
