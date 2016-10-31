class Integrations extends React.Component {
    constructor(props) {
        super(props);
    }

    renderSlackIntegration(integration) {
        const { message_types, api_key, id } = integration;
        return (
            <div
                key={id}
                className={`${id}-integration`}
            >
                <p>
                    Configure a Slack integration to notify
                    your channel when supported events happen on SupermarKit.
                </p>
                <ul
                    id={id}
                    className='collapsible'
                    data-collapsible='accordion'
                    >
                    {Object.keys(message_types).map((key, index) => {
                        const {
                            name,
                            fields,
                            exampleInput,
                            exampleFields,
                            description,
                            id,
                        } = message_types[key];
                        return (
                            <li key={id}>
                                <div className='collapsible-header'>
                                    <strong>{name}</strong>
                                </div>
                                <div className='collapsible-body'>
                                    <SlackMessage
                                        id={id}
                                        message={exampleInput}
                                        fields={fields}
                                        description={description}
                                        exampleFields={exampleFields}
                                        />
                                </div>
                            </li>
                        );
                    })}
                </ul>
            </div>
        )
    }

    renderIntegrationContent() {
        const { integrations } = this.props;
        return (
            <div className='integrations-content'>
                {integrations.map(integration => {
                    const { name } = integration;
                    switch (name) {
                        default:
                            return this.renderSlackIntegration(integration);
                    };
                })}
            </div>
        );
    }

    renderIntegrationTabs() {
        const { integrations } = this.props
        const tabs = integrations.map((integration, index) => {
            const { name, id } = integration;
            return (
                <li
                    key={id}
                    className='tab'>
                    <a className='dark' href={id}>
                        <i className={`fa fa-${id}`} />
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
                            <div className='integrations'>
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

Integrations.propTypes = {
    integrations: React.PropTypes.array.isRequired,
}
