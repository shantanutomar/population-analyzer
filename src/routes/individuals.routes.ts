import { Router } from 'express';

import {getIndividualsInState} from "../controllers/individuals.controller.js";

const individualsRoutes = Router();

individualsRoutes.get('/state/:stateId', getIndividualsInState);

export default individualsRoutes;