import pg, {Pool, PoolConfig} from "pg";

const databaseConfig: PoolConfig = {
    host: process.env.POSTGRES_HOST,
    user: process.env.POSTGRES_USER,
    database: process.env.POSTGRES_DATABASE,
    password: process.env.POSTGRES_PASSWORD,
    port: parseInt(process.env.POSTGRES_PORT || "5432")
}

const pool: Pool = new pg.Pool(databaseConfig);

export default pool;
