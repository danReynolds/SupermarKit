class SlackMessage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            message: props.message,
        };

        this.onMessageChange = this.onMessageChange.bind(this);
    }

    onMessageChange(e) {
        this.setState({ message: e.target.value });
    }

    renderMessageOutput() {
        const { message } = this.state;
        const { fields, exampleFields } = this.props;

        return fields.reduce((acc, field) => (
            acc.replace(`{${field}}`, exampleFields[field])
        ), message);
    }

    render() {
        const { id, description } = this.props;
        const { message } = this.state;
        return (
            <div className='slack-message'>
                <label htmlFor={id}>Description</label>
                <p id={`description-${id}`}>{description}</p>
                <label htmlFor={id}>Message Format</label>
                <input
                    onChange={this.onMessageChange}
                    id={id}
                    type='text'
                    value={message}
                />
                <label htmlFor={id}>Message Output</label>
                <p className={`message-output-${id}`}>
                    {this.renderMessageOutput()}
                </p>
            </div>
        );
    }
}

SlackMessage.propTypes = {
    message: React.PropTypes.string,
    id: React.PropTypes.string,
    fields: React.PropTypes.array,
    exampleFields: React.PropTypes.object,
    description: React.PropTypes.string,
};
