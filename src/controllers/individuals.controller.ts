import {Request, Response} from "express";
import {QueryResult} from "pg";

import pool from '../db/connection.js';
import {getIndividualsInStateMapper} from "../mappers/getIndividualsInState.mapper.js";
import {IndividualsEntity} from "../entities/individuals.entity.js";
import {IndividualsResponse} from "../dto/individuals.response.js";

/**
 * getIndividualsInState
 * @param {object} req
 * @param {object} res
 * @returns {object}
 */

const getIndividualsInState = async (req: Request, res: Response): Promise<void> => {

    const stateId = req.params.stateId;
    const getIndividualsInStateQuery = `SELECT * FROM individuals WHERE state_id = '${stateId}'`;

    console.log('getIndividualsInStateQuery', getIndividualsInStateQuery);

    try {
        const result: QueryResult = await pool.query(getIndividualsInStateQuery);
        if (result.rows.length > 0) {
            const individualsResponse: IndividualsResponse[] = getIndividualsInStateMapper.toResponse(result.rows as IndividualsEntity[]);
            res.json(individualsResponse)
        } else {
            res.status(200).json({ message: `No individuals lives in this state.` })
        }
    } catch (error) {
        res.status(500).json({ error: error });
    }
};

export {
    getIndividualsInState,
};
