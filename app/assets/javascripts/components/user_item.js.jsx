var UserItem = React.createClass({
    propTypes: {
        index: React.PropTypes.number.isRequired,
        modalTrigger: React.PropTypes.func.isRequired,
        payable: React.PropTypes.bool.isRequired,
        user: React.PropTypes.shape({
            id: React.PropTypes.number.isRequired,
            image: React.PropTypes.string.isRequired,
            name: React.PropTypes.string.isRequired,
            balance: React.PropTypes.number.isRequired
        })
    },

    handleClick: function(e) {
        this.props.modalTrigger(parseInt(e.target.getAttribute('data-index')));
    },

    render: function() {
        if (this.props.index) {
            var payContent = (
                <div
                    className='btn'
                    data-index={this.props.index}
                    onClick={this.handleClick}
                >
                    Pay
                </div>
            );
        }

        return (
            <li className='user-item'>
                <UserItemContent user={this.props.user}/>
                {payContent}
            </li>
        );
    }
});
