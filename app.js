global.express = require("express");
global.app = express();
global.bodyParser = require('body-parser');

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({
    extended: true,
    limit: '110mb'
}))

// parse application/json
app.use(bodyParser.json({
    limit: '50mb'
}))

app.use(express.static("myApp")); // myApp will be the same folder name.

app.get("/", function (req, res, next) {
    res.redirect("/");
});


app.listen(process.env.PORT || 8080);
