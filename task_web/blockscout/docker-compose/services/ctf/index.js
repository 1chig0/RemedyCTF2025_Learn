const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const app = express();
const port = 8080;
const fs = require('node:fs');
const FormData = require('form-data');
const { Readable } = require('stream');

var verifiedList = [];

const intervalID = setInterval(backup, 15000);

function backup() {
    let currentDate = Date.now();
    exec('sh -c "tar -cf ../backups/${currentDate}.tar *"', {cwd: "./logs/"}, (error, stdout, stderr) => {
        if(error) {
            console.error("Error", error.message);
            return;
        }
        else if(stderr) {
            console.error("Tar Error", stderr);
            return;
        }
        console.log("Successfully backed up all of the contract logs")

    });
}
app.use(express.static('public'));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, './public/index.html'));
})

app.get('/event', (req, res) => {
    res.sendFile(path.join(__dirname, './public/event.html'));
})

app.get('/verify', (req, res) => {
    res.sendFile(path.join(__dirname, './public/verify.html'));
})

app.get('/getevent', async (req, res) => {
    const response = await fetch(`http://backend:4000/api/v2/addresses/${req.query.address}`);
    let respJson = await response.json();
    if(!respJson.name) {
        console.error("Not contract");
        res.send('Not contract');
    }
    else {
        let secondResponse = await fetch(`http://backend:4000/api/v2/smart-contracts/${req.query.address}`);
        let secondJson = await secondResponse.json();
        let contractPath = secondJson.file_path;
        let values = [];
        const response = await fetch(`http://backend:4000/api/v2/addresses/${req.query.address}/logs`);
        let txJson = await response.json();
        txJson.items.forEach(txLog => {
            txLog.decoded.parameters.forEach(param => {
                values.push(param.value);
            });
        });
        try {
            fs.writeFileSync("logs/" + contractPath.replace('/', '\u2215'), values.join('\n'));
            res.send(txJson);
        }
        catch (err) {
            console.error(err);
            res.send("Something went wrong");
        }
    }
});

app.get('/blocks', async (req, res) => {
    const response = await fetch(`http://backend:4000/api/v2/main-page/blocks`);
    res.send(await response.json());
});

app.get('/transactions', async (req, res) => {
    const response = await fetch(`http://backend:4000/api/v2/main-page/transactions`);
    res.send(await response.json());
});

app.post('/verify', express.json() , (req, res) => {
    let jsonData = req.body;
    let contractAddress = jsonData.address;
    let compiler = jsonData.compiler;
    let contractName = jsonData.contractName;
    let constructorInput = jsonData.constructorInput;
    let licenseInput = jsonData.licenseInput;
    let contractJson = jsonData.jsonData;

    const formBody = new FormData();
    formBody.append("compiler_version", compiler);
    formBody.append("contract_name", contractName);
    formBody.append('files[0]', contractJson, { filename: 'action1.json', contentType: 'application/json' });
    formBody.append("autodetect_constructor_args", "false");
    formBody.append("constructor_args", constructorInput);
    formBody.append("license_type", licenseInput);
    formBody.submit(`http://backend:4000/api/v2/smart-contracts/${contractAddress}/verification/via/standard-input`, function(err, formRes) {
        if (err) {
            res.send('Something went wrong');
        }
        else {
            console.log(formRes.statusCode);
            res.send("Done");
        }
    });
});

app.get('/check', (req, res) => {
    fetch(`http://backend:4000/api/v2/smart-contracts/${req.query.address}`)
        .then(response => response.json())
        .then(data => {
            if(data.name){
                res.send(data.name);
            }
            else{
                res.send("Not verified");
            }
        })
        .catch(error => {
            console.error('Error fetching contract:', error);
        });
});

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})