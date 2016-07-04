var Dashboard = React.createClass({
    propTypes: {
        manage_url: React.PropTypes.string.isRequired,
        checkout_url: React.PropTypes.string.isRequired,
        itemList: React.PropTypes.object.isRequired,
        emailer: React.PropTypes.object.isRequired,
        location: React.PropTypes.object.isRequired
    },

    getInitialState: function() {
        return {
            recipeLength: this.props.recipeLength || 0
        };
    },

    updateRecipeLength: function(recipeLength) {
        this.setState({
            recipeLength: recipeLength
        });
    },

    render: function() {
        return (
            <div className='dashboard'>
                <div className='row'>
                    <div className='col l6 dashboard-card'>
                        <ItemList
                            recipeLength={this.state.recipeLength}
                            {...this.props.itemList}/>
                        <Recipes
                            updateRecipeLength={this.updateRecipeLength}
                            {...this.props.recipes}/>
                        <div className='fixed-action-btn'>
                            <a className='btn-floating btn-large'>
                                <i className='large material-icons'>mode_edit</i>
                            </a>
                            <ul>
                                <li>
                                    <a className='btn-floating' href={this.props.manage_url}>
                                        <i className='fa fa-users'/>
                                    </a>
                                    <div className='btn-label'>Manage Kit</div>
                                </li>
                                <li>
                                    <a className='btn-floating' href={this.props.checkout_url}>
                                        <i className='fa fa-shopping-basket'/>
                                    </a>
                                    <div className='btn-label'>Checkout</div>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <div className='col l6 dashboard-card'>
                        <Emailer
                            {...this.props.emailer}/>
                        <Location
                            {...this.props.location}/>
                    </div>
                </div>
            </div>
        );
    }
})
