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
        const { user: { id, name, image, links: { get_url } } } = this.props;
        var balance = this.balanceResult(this.props.user.balance);

        return (
            <div className='user-item-content'>
                <img src={image}/>
                <div className='name-wrapper'>
                    <label htmlFor={'name-section-' + id}>Name</label>
                    <div className='name-section' id={'name-section-' + id}>
                        <a
                            className='dark'
                            id={`name-section-${id}`}
                            href={get_url}
                        >{name}</a>
                    </div>
                </div>
                <div className={'balance-wrapper ' + balance.class}>
                    <label className='balance-label' htmlFor={'balance-section-' + id}>Kit balance</label>
                    <div className='balance-section' id={'balance-section-' + id}>
                        <i className='material-icons'>{balance.icon}</i>
                        <div className='balance'>${Math.abs(this.props.user.balance).toFixed(2)}</div>
                    </div>
                </div>
            </div>
        );
    }
});
