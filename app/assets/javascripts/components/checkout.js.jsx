var Checkout = React.createClass({
    propTypes: {
        grocery_id: React.PropTypes.number.isRequired,
        users: React.PropTypes.array.isRequired,
        total: React.PropTypes.number.isRequired,
        redirect_url: React.PropTypes.string.isRequired,
        uploader_id: React.PropTypes.number
    },

    getInitialState: function() {
        return {
            users: this.props.users.map(function(user) {
                var uploader_id = this.props.uploader_id;
                var contribution = uploader_id && user.id === uploader_id ? this.props.total : 0;
                return Object.assign(
                    user,
                    {
                        contributed: true,
                        contribution: contribution
                    }
                )
            }.bind(this))
        };
    },

    getIndex: function(e) {
        return parseInt($(e.target).closest('li').data('index'));
    },

    handleContributionToggle: function(e) {
        this.toggleContribution(this.getIndex(e));
    },

    handleContribution: function(e) {
        this.updateContribution(this.getIndex(e), parseFloat(e.target.value));
    },

    handleSubmit: function(e) {
        e.preventDefault();
        $.ajax({
            method: 'PATCH',
            url: this.props.url,
            dataType: 'html',
            contentType: 'application/json',
            data: JSON.stringify({
                grocery: {
                    payments: this.state.users.reduce(function(acc, user) {
                        if (user.contributed) {
                            acc.push(
                                {
                                    user_id: user.id,
                                    price: user.contribution
                                }
                            )
                        }
                        return acc;
                    }, [])
                }
            })
        }).done(function() {
            window.location = this.props.redirect_url;
        }.bind(this));
    },

    updateContribution: function(index, value) {
        this.setState({
            users: React.addons.update(
                this.state.users,
                {
                    [index]: {
                        contribution: {
                            $set: value
                        }
                    }
                }
            )
        });
    },

    toggleContribution: function(index) {
        this.setState({
            users: React.addons.update(
                this.state.users,
                {
                    [index]: {
                        contributed: {
                            $set: !this.state.users[index].contributed
                        },
                        contribution: {
                            $set: 0
                        }
                    }
                }
            )
        });
    },

    renderUsers: function() {
        var userContent = this.state.users.map(function(user, index) {
            var userPayment = 'user-' + user.id + '-payment',
                userContribution = 'user-' + user.id + '-contribution';

            return (
                <li
                    className='user-item'
                    key={index}
                    data-index={index}>
                    <UserItemContent user={user}/>
                    <div className='input-field'>
                        <label htmlFor={userPayment}>Contribution</label>
                        <input
                            disabled={!user.contributed}
                            id={userPayment}
                            onChange={this.handleContribution}
                            value={user.contribution || ''}
                            type='number'>
                        </input>
                    </div>
                    <input
                        id={userContribution}
                        type='checkbox'
                        className='filled-in'
                        onChange={this.handleContributionToggle}
                        checked={user.contributed}/>
                    <label
                        className='contribution-checkbox'
                        htmlFor={userContribution}/>
                </li>
            );
        }.bind(this));

        return (
            <ul>
                {userContent}
            </ul>
        );
    },

    render: function() {
        var total = this.state.users.reduce(function(acc, user) {
            if (user.contributed && user.contribution) {
                acc += user.contribution;
            }
            return acc;
        }, 0);

        return (
            <div className='checkout'>
                <div className='card'>
                    <form
                        onSubmit={this.handleSubmit}
                        className='checkoutForm'>
                        <div className='card-content'>
                            <h3>Pay for your groceries</h3>
                            <div className='row'>
                                <div className='col l12'>
                                    {this.renderUsers()}
                                </div>
                            </div>
                            <div className='totals'>
                                <div className='total'>Total: ${total}</div>
                            <div className='estimated-total'>Estimated Total: ${this.props.total}</div>
                            </div>
                        </div>
                        <div className='card-action'>
                            <input
                                type='submit'
                                value='Checkout'
                                className='btn'/>
                        </div>
                    </form>
                </div>
            </div>
        );
    }
})
