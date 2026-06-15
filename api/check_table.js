const db = require('./src/services/db.service');

async function run() {
    try {
        const rows = await db.execute("SELECT * FROM dbo.UserSimulationClients");
        console.log("UserSimulationClients rows:", rows[0]);
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

run();
