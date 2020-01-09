module.exports = (Sequelize, DataTypes) => {
    const PaymentType = Sequelize.define('PaymentType', {

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
        parentCode: {
            type: DataTypes.STRING,
            allowNull: false,
            field: 'parent_code'
        },
    },{
        freezeTableName: true,
        tableName: 'cls_payment_type',
        schema: 'main'
    });

    return PaymentType;
};