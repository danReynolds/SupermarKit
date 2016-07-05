var UserManagement = React.createClass({
    propTypes: {
        users: React.PropTypes.array.isRequired
    },

    renderUserItems: function() {
        return this.props.users.map(function(user) {
            return (
                <UserItem
                    key={user.id}
                    user={user} />
            );
        });
    },

    render: function() {
        return (
            <div className='card'>
                <div className='card-content'>
                    <h3>Kit members</h3>
                    {this.renderUserItems()}
                </div>
            </div>
        )
    }
});
