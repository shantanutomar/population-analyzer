import swaggerAutogen from 'swagger-autogen';

const outputFile = '../src/swagger.json'
const endpointsFiles = ['../dist/app.js']

swaggerAutogen({openapi: '3.0.0'})(outputFile, endpointsFiles).then(async () => {
});