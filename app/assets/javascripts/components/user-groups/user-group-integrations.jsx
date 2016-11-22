class UserGroupIntegrations extends React.Component {
    constructor(props) {
        super(props);

        this.onAPIChange = this.onAPIChange.bind(this);
    }

    onAPIChange(e) {
        const { onSlackFieldChange } = this.props;
        const { target: { value } } = e;
        onSlackFieldChange('api_token', value);
    }

    renderSlackIntegration(id, integration) {
        const { message_types, api_token } = integration;
        const { onSlackMessageChange } = this.props;
        const apiId = 'slack-api-key';
        return (
            <div
                key={id}
                className={`${id}-integration`}
            >
                <p>
                    Set your Slack API key and enable events to receive in your
                    team's channel from SupermarKit.
                </p>
                <label htmlFor={apiId}>API Key</label>
                <input
                    type='text'
                    id={apiId}
                    value={api_token}
                    onChange={this.onAPIChange}
                />
                <label htmlFor={id}>Events</label>
                <CollapsibleWrapper id={id}>
                    {message_types.map((message_type, index) => {
                        const { name: messageName } = message_type;
                        return (
                            <SlackMessage
                                key={index}
                                index={index}
                                onSlackMessageChange={onSlackMessageChange}
                                {...message_type}
                            />
                        );
                    })}
                </CollapsibleWrapper>
            </div>
        )
    }

    renderIntegrationContent() {
        const { integrations } = this.props;
        return (
            <div className='integrations-content'>
                {Object.keys(integrations).map(key => {
                    switch (key) {
                        default:
                            return this.renderSlackIntegration(key,integrations[key]);
                    };
                })}
            </div>
        );
    }

    renderIntegrationTabs() {
        const { integrations } = this.props
        const tabs = Object.keys(integrations).map(key => {
            const { name } = integrations[key];
            return (
                <li
                    key={key}
                    className='tab'>
                    <a className='dark' href={key}>
                        <i className={`fa fa-${key}`} />
                        {name}
                    </a>
                </li>
            );
        });
        return (
            <ul className='tabs'>
                {tabs}
            </ul>
        );
    }

    render() {
        return (
            <div className='card'>
                <div className='card-content full-width dark'>
                    <div className='card-header'>
                        <h3>Integrations</h3>
                    </div>
                    <div className='row'>
                        <div className='col l12'>
                            <div className='user-group-integrations'>
                                {this.renderIntegrationTabs()}
                                {this.renderIntegrationContent()}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

UserGroupIntegrations.propTypes = {
    integrations: React.PropTypes.object.isRequired,
    onSlackMessageChange: React.PropTypes.func,
    onSlackFieldChange: React.PropTypes.func,
}
