module.exports = (Sequelize, DataTypes) => {
    const Practice = Sequelize.define('Practice', {

        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true,
            field: 'id'
        },
        name: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        code: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        content: {
            type: DataTypes.STRING,
            allowNull: false
        },
        number: {
            type: DataTypes.STRING,
            allowNull: false
        }
    },{
        freezeTableName: true,
        tableName: 'reg_practice',
        schema: 'main'
    });

    return Practice;
};