function tryVerify(contractAddress, compiler, contractName, constructorInput, licenseInput, jsonData) {
    fetch(`/verify`, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            "address": contractAddress,
            "compiler": compiler,
            "contractName": contractName,
            "constructorInput": constructorInput,
            "licenseInput": licenseInput,
            "jsonData": jsonData
        })
    })
        .then(response => response.text())
        .then(data => {
            alert(data);
            console.log(alert);
        })
        .catch(error => {
            console.error('Error fetching transactions:', error);
        });
}

function checkStatus(contractAddress) {
    fetch(`/check?address=${contractAddress}`)
        .then(response => response.text())
        .then(data => {
            alert("Verified contract: " + data);
            console.log(alert);
        })
        .catch(error => {
            console.error('Error fetching contract:', error);
        });
}

window.onload = function () {
    const contractForm = document.getElementById('contract-form');
    const jsonInput = document.getElementById('contract-json');
    const addressInput = document.getElementById('address-input');
    const compilerInput = document.getElementById("compiler-input");
    const contractInput = document.getElementById("contract-input");
    const constructorInput = document.getElementById("constructor-input");
    const licenseInput = document.getElementById("license-input");

    const checkButton = document.getElementById("check-button");

    contractForm.addEventListener("submit", (e) => {
        e.preventDefault();
        
        if(addressInput.value == "") {
            console.error("No input");
            alert("No input")
        }
        else {
            tryVerify(addressInput.value, compilerInput.value, contractInput.value, constructorInput.value, licenseInput.value, jsonInput.value);
        }
    });
    checkButton.addEventListener('click', (e) => {
        checkStatus(addressInput.value);
    });
};
