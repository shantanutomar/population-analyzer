import {IndividualsEntity} from "../entities/individuals.entity.js";
import {IndividualsResponse} from "../dto/individuals.response.js";

export const getIndividualsInStateMapper = {
    toResponse: (individuals: IndividualsEntity[]): IndividualsResponse[] => {
        return individuals.map(individual => {
            return {
                firstName: individual.first_name,
                lastName: individual.last_name
            }
        })
    },
}