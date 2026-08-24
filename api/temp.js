require('dotenv').config({ path: './.env' });
const db = require('./src/services/db.service');
(async () => {
    try {
        const text = await db.execute("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.sp_GetUserActiveSites')) AS definition");
        console.log("SP DEFINITION:\n", text[0][0].definition);
    } catch(err) {
        console.error(err);
    }
    process.exit(0);
})();
