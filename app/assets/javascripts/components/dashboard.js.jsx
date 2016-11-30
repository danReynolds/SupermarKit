var Dashboard = React.createClass({
    propTypes: {
        manage_url: React.PropTypes.string.isRequired,
        receipt_url: React.PropTypes.string.isRequired,
        itemList: React.PropTypes.object.isRequired,
        emailer: React.PropTypes.object.isRequired,
        location: React.PropTypes.object.isRequired
    },

    getInitialState: function() {
        return {
            recipes: this.props.recipes.selection
        };
    },

    updateRecipes: function(recipes) {
        this.setState({
            recipes: recipes
        });
    },

    render: function() {
        return (
            <div className='dashboard'>
                <div className='row'>
                    <div className='col l6 dashboard-card'>
                        <ItemList
                            recipes={this.state.recipes}
                            {...this.props.itemList}/>
                        <Recipes
                            updateRecipes={this.updateRecipes}
                            {...this.props.recipes}/>
                        <div className='fixed-action-btn'>
                            <a className='btn-floating btn-large light'>
                                <i className='large material-icons'>mode_edit</i>
                            </a>
                            <ul>
                                <li>
                                    <div className='btn-label'>Manage Kit</div>
                                    <a className='btn-floating btn-small' href={this.props.manage_url}>
                                        <i className='fa fa-users'/>
                                    </a>
                                </li>
                                <li>
                                    <div className='btn-label'>Checkout</div>
                                    <a className='btn-floating btn-small' href={this.props.receipt_url}>
                                        <i className='fa fa-shopping-basket'/>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <div className='col l6 dashboard-card'>
                        <Location
                            {...this.props.location}/>
                        <Emailer
                            {...this.props.emailer}/>
                    </div>
                </div>
            </div>
        );
    }
})
