import { Action, LifeSituation, PaymentType } from '../models';

module.exports = {

  async list(req, res) {
    try {
      const list = await Action.findAll({
          attributes: {
              exclude: ['createdAt', 'password'],
          },
      });
      return res.status(200).send(list);
    } catch (err) {
      throw new Error(err);
      return res.status(500).send(err);
    }
  },

};
