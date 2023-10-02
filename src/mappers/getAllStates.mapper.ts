import {StatesEntity} from "../entities/states.entity.js";
import {StatesResponse} from "../dto/states.response.js";

export const getAllStatesMapper = {
    toResponse: (states: StatesEntity[]): StatesResponse[] => {
        return states.map(state => {
            return {
                shapeId: state.shape_id,
                name: state.name,
            }
        })
    },
}