class SlackMessage extends React.Component {
    constructor(props) {
        super(props);

        this.onFormatChange = this.onFormatChange.bind(this);
        this.onEnabledChange = this.onEnabledChange.bind(this);
    }

    onFormatChange(e) {
        const { target: { value } } = e;
        const { onSlackMessageChange, index } = this.props;
        onSlackMessageChange(index, 'format', value);
    }

    onEnabledChange() {
        const { onSlackMessageChange, index, enabled } = this.props;
        onSlackMessageChange(index, 'enabled', !enabled);
    }

    renderMessageOutput() {
        const { fields, exampleFields, format } = this.props;

        return fields.reduce((acc, field) => (
            acc.replace(`{${field}}`, exampleFields[field])
        ), format);
    }

    render() {
        const { index, description, format, name, enabled } = this.props;
        const messageId = `message-${index}`;
        const descriptionId = `description-${index}`;
        const formatId = `format-${index}`;
        const enabledId = `enabled-${index}`;
        return (
            <Collapsible className='slack-message'>
                <div>
                    <strong>{name}</strong>
                    <input
                        id={enabledId}
                        type='checkbox'
                        checked={enabled}
                        className='filled-in'
                        onChange={this.onEnabledChange}
                    />
                    <label htmlFor={enabledId}/>
                </div>
                <div>
                    <label htmlFor={descriptionId}>Description</label>
                    <p id={descriptionId}>{description}</p>
                    <label htmlFor={messageId}>Message Format</label>
                    <input
                        onChange={this.onFormatChange}
                        id={messageId}
                        type='text'
                        value={format}
                    />
                <label htmlFor={formatId}>Message Output</label>
                    <p className={formatId}>
                        {this.renderMessageOutput()}
                    </p>
                </div>
            </Collapsible>
        );
    }
}

SlackMessage.propTypes = {
    index: React.PropTypes.number,
    name: React.PropTypes.string,
    fields: React.PropTypes.array,
    exampleFields: React.PropTypes.object,
    description: React.PropTypes.string,
    format: React.PropTypes.string,
    onSlackMessageChange: React.PropTypes.func,
    enabled: React.PropTypes.bool,
};
