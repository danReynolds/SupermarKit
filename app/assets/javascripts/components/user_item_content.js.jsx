var UserItemContent = React.createClass({
    propTypes: {
        user: React.PropTypes.shape({
            id: React.PropTypes.number.isRequired,
            image: React.PropTypes.string.isRequired,
            name: React.PropTypes.string.isRequired,
            balance: React.PropTypes.number.isRequired
        })
    },

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
    },

    render: function() {
        var balance = this.balanceResult(this.props.user.balance);

        return (
            <div className='user-item-content'>
                <div className='valign-wrapper'>
                    <img src={this.props.user.image}/>
                    <p className='name'>{this.props.user.name}</p>
                </div>
                <div className={'balance-wrapper ' + balance.class}>
                    <label className='balance-label' htmlFor={'balance-section' + this.props.user.id}>Kit balance</label>
                    <div className='balance-section' id={'balance-section-' + this.props.user.id}>
                        <i className='material-icons'>{balance.icon}</i>
                        <div className='balance'>${Math.abs(this.props.user.balance).toFixed(2)}</div>
                    </div>
                </div>
            </div>
        );
    }
});
