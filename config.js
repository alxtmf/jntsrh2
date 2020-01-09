if (process.env.NODE_ENV !== 'production') {
  require('now-env');
}

const Sequelize = require('sequelize');

module.exports = {
  development: {
    username: 'pfgbiiflnjmrpq',
    password: '8fc93e9bbe304041abfeb8f3c700ebcf3785d79ef807a81e833bafe5c37f828f',
    database: 'd3idjrep5lgevm',
    host: 'ec2-50-17-246-114.compute-1.amazonaws.com',
    port: 5432,
    dialect: 'postgres',
    dialectOptions: {
          ssl: true,
    },
    define: {
          defaultScope: {
              attributes: {
                  exclude: ["createdAt", "updatedAt"]
              }
          }
    },

  },
  production: {
    username: 'pfgbiiflnjmrpq',
    password: '8fc93e9bbe304041abfeb8f3c700ebcf3785d79ef807a81e833bafe5c37f828f',
    database: 'd3idjrep5lgevm',
    host: 'ec2-50-17-246-114.compute-1.amazonaws.com',
    port: 5432,
    dialect: 'postgres',
    dialectOptions: {
      ssl: true,
    },
    define: {
       defaultScope: {
         attributes: {
           exclude: ["createdAt", "updatedAt"]
         }
       }
    },
  },
  session: {
    secret: process.env.PRODUCTION_SECRET || 'placeholdersecret',
  },
};
