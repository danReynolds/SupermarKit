var UserItem = React.createClass({
    mixins: [BalanceCalculator],

    propTypes: {
        user: React.PropTypes.shape({
            id: React.PropTypes.number.isRequired,
            image: React.PropTypes.string.isRequired,
            name: React.PropTypes.string.isRequired,
            balance: React.PropTypes.number.isRequired
        })
    },

    render: function() {
        var balance = this.balanceResult(this.props.user.balance);

        return (
            <li className='user-content'
                data-index={this.props.user.id}>
                <div className='valign-wrapper'>
                    <img src={this.props.user.image}/>
                    <p className='name'>{this.props.user.name}</p>
                </div>
                <div className={'balance-wrapper ' + balance.class}>
                    <label className='balance-label' htmlFor={'balance-section' + this.props.user.id}>Kit balance</label>
                    <div className='balance-section' id={'balance-section-' + this.props.user.id}>
                        <i className='material-icons'>{balance.icon}</i>
                        <div className='balance'>${Math.abs(this.props.user.balance)}</div>
                    </div>
                </div>
            </li>
        );
    }
});
