var Dashboard = React.createClass({
    propTypes: {
        checkout_url: React.PropTypes.string.isRequired,
        itemList: React.PropTypes.object.isRequired,
        emailer: React.PropTypes.object.isRequired
    },

    render: function() {
        return (
            <div className='dashboard'>
                <div className='row'>
                    <div className='col l6 dashboard-card'>
                        <ItemList
                            {...this.props.itemList}/>
                        <Recipes
                            {...this.props.recipes}/>
                        <div className='fixed-action-btn'>
                            <a className='btn-floating btn-large'>
                                <i className='large material-icons'>mode_edit</i>
                            </a>
                            <ul>
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
                    </div>
                </div>
            </div>
        );
    }
})
