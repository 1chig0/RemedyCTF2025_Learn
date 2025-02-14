function shortenHash(hash) {
    const firstPart = hash.slice(0, 6);
    const lastPart = hash.slice(-4);
    
    return `${firstPart}...${lastPart}`;
}

function updateData() {
    const blocksTable = document.getElementById('blocks-table');

    fetch('/blocks')
        .then(response => response.json())
        .then(data => {
            blocksTable.innerHTML = ''; // Clear loading message

            // Iterate over each transaction and display it
            data.forEach(block => {
                const blockElement = document.createElement('tr');

                // Create a summary of key transaction details
                blockElement.innerHTML = `
                    <td>${block.height}</td>
                    <td>${shortenHash(block.miner.hash)}</td>
                    <td>${block.tx_count}</td>
                `;

                blocksTable.appendChild(blockElement);
            });
        })
        .catch(error => {
            console.error('Error fetching transactions:', error);
        });
    
    const transactionTable = document.getElementById('transaction-table');

    fetch('/transactions')
        .then(response => response.json())
        .then(data => {
            transactionTable.innerHTML = ''; // Clear loading message

            // Iterate over each transaction and display it
            data.forEach(transaction => {
                const transactionElement = document.createElement('tr');

                // Create a summary of key transaction details
                transactionElement.innerHTML = `
                    <td>${shortenHash(transaction.hash)}</td>
                    <td><a href="event?addr=${transaction.from.hash}">${shortenHash(transaction.from.hash)}</a></td>
                    <td><a href="event?addr=${transaction.to.hash}">${shortenHash(transaction.to.hash)}</a></td>
                    <td>${transaction.to.is_contract ? "True" : "False"}</td>
                `;

                transactionTable.appendChild(transactionElement);
            });
        })
        .catch(error => {
            console.error('Error fetching transactions:', error);
        });
}

window.onload = function () {
    updateData();
    setInterval(updateData, 3000);
};
