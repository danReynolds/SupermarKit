var BalanceCalculator = {
    balanceResult: function(balance) {
        var balanceData;
        if (balance === 0) {
            balanceData = {
                icon: 'trending_flat',
                class: 'zero'
            }
        } else if (balance < 0) {
            balanceData = {
                icon: 'call_made',
                class: 'positive'
            }
        } else {
            balanceData = {
                icon: 'call_received',
                class: 'negative'
            }
        }
        return balanceData;
    }
};
