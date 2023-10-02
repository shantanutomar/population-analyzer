import {Request, Response} from "express";
import {QueryResult} from "pg";

import pool from '../db/connection.js';
import {StatesEntity} from "../entities/states.entity.js";
import {getAllStatesMapper} from "../mappers/getAllStates.mapper.js";
import {StatesResponse} from "../dto/states.response.js";

/**
 * Add A Bus
 * @param {object} req
 * @param {object} res
 * @returns {object} reflection object
 */
const getAllStates = async (req: Request, res: Response): Promise<void> => {

    const getAllStatesQuery: string = `SELECT * FROM states ORDER BY name ASC`;

    console.log('getAllStatesQuery', getAllStatesQuery);

    try {
        const result: QueryResult = await pool.query(getAllStatesQuery);
        if(result.rows.length > 0) {
            const stateResponse: StatesResponse[] = getAllStatesMapper.toResponse(result.rows as StatesEntity[]);
            res.json(stateResponse)
        } else {
            res.status(200).json({ message: 'No states found.' })
        }
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
};

export {
    getAllStates,
};
