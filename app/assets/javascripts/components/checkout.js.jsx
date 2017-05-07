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

    componentDidMount: function() {
        // Hack: Input fields have a dynamic method defined on turbolinks
        // load by Materialize-JS that needs to be called
        $('.collapsible').collapsible({ accordion: false });

        document.addEventListener('turbolinks:load', setTimeout(() => (
            Materialize.updateTextFields()
        ), 1));
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
            method: 'POST',
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
                        <label htmlFor={userPayment}>Amount</label>
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
                <form
                    onSubmit={this.handleSubmit}
                    className='checkoutForm'>
                    <div className='card'>
                        <div className='card-content'>
                            <div className='card-header'>
                                <h3>Payments</h3>
                            </div>
                            <PaymentList
                            />
                        </div>
                        <div className='card-action'>
                            <input
                                type='submit'
                                value='Checkout'
                                className='btn'/>
                        </div>
                    </div>
                </form>
            </div>
        );
    }
})
