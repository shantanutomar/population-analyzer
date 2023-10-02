import { Router } from 'express';

import {getAllStates } from "../controllers/states.controller.js";

const statesRoutes = Router();

statesRoutes.get('/', getAllStates);

export default statesRoutes;