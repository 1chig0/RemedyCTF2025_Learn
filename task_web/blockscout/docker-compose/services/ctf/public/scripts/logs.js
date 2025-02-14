function updateData(address) {
    const logsTable = document.getElementById('log-table');
    fetch(`/getevent?address=${address}`)
        .then(response => response.json())
        .then(data => {
            logsTable.innerHTML = ''; // Clear loading message

            // Iterate over each transaction and display it
            data.items.forEach(log => {
                log.decoded.parameters.forEach(parameter => {
                    const logElement = document.createElement('tr');

                    // Create a summary of key transaction details
                    logElement.innerHTML = `
                        <td>${log.index}</td>
                        <td>${parameter.name}</td>
                        <td>${parameter.type}</td>
                        <td>${parameter.value}</td>
                    `;

                    logsTable.appendChild(logElement);
                });
            });
        })
        .catch(error => {
            console.error('Error fetching transactions:', error);
        });
}

window.onload = function () {
    const logForm = document.getElementById('log-form');
    const addressInput = document.getElementById('address-input');
    logForm.addEventListener("submit", (e) => {
        e.preventDefault();
        
        if(addressInput.value == "") {
            console.error("No input");
            alert("No input")
        }
        else {
            updateData(addressInput.value);
        }
    });

    const queryString = window.location.search;
    if(!queryString) {
        return;
    }
    const urlParams = new URLSearchParams(queryString);
    const addr = urlParams.get('addr');
    if(!addr) {
        return;
    }
    addressInput.value = addr;
    updateData(addr);
};
