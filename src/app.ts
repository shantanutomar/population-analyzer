import 'dotenv/config';
import express from 'express';

import statesRoutes from "./routes/states.routes.js";
import individualsRoutes from "./routes/individuals.routes.js";

const app = express();

app.use('/states', statesRoutes);
app.use('/individuals', individualsRoutes);

app.listen(process.env.PORT, () => {
    console.log(`Server started on port ${process.env.PORT}`);
});

export default app;
