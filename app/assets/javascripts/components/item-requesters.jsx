class ItemRequesters extends React.Component {
    static propTypes = {
        users: React.PropTypes.array,
        requesterIds: React.PropTypes.array,
        editable: React.PropTypes.bool,
        index: React.PropTypes.number
    }

    static defaultProps = {
        editable: false
    }

    constructor(props) {
        super(props);
    }

    render() {
        const { users, requesterIds, index } = this.props;
        const requesterImages = users.filter(user => requesterIds.includes(user.id))
            .map(user => {
                const { id, image } = user;
                return <img key={`requester-${index}-${id}`} src={image} />
            });
        return (
            <div className='item-requesters'>
                {requesterImages}
            </div>
        )
    }
}
