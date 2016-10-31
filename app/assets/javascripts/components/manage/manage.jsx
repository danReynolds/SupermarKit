const { update } = React.addons;

class Manage extends React.Component {
    constructor(props) {
        super(props);

        this.state = this.props;
        this.onFieldChange = this.onFieldChange.bind(this);
        this.onCheckboxChange = this.onCheckboxChange.bind(this);
        this.onFileChange = this.onFileChange.bind(this);
    }

    onFieldChange(e) {
        const { target } = e;
        const field = target.getAttribute('name');
        this.setState(
            update(this.state, {
                kitUpdate: {
                    [field]: { $set: target.value }
                }
            })
        );
    }

    onCheckboxChange(e) {
        const { target } = e;
        const field = target.getAttribute('name');
        this.setState(
            update(this.state, {
                kitUpdate: {
                    [field]: { $set: target.checked }
                }
            })
        );
    }

    onFileChange(e) {
        const { target: { files } } = e;
        this.setState({ banner: files[0] });
    }

    render() {
        const {
            banner,
            members,
            integrations,
            kitUpdate,
        } = this.state;
        return (
            <div className='manage'>
                <div className='row'>
                    <div className='col l8 offset-l2'>
                        <KitUpdate
                            {...kitUpdate}
                            onFieldChange={this.onFieldChange}
                            onCheckboxChange={this.onCheckboxChange}
                        />
                        <KitBanner
                            banner={banner}
                            onFileChange={this.onFileChange}
                        />
                    </div>
                    <div className='col l6'>
                        <div className='card'>
                            <div className='card-content'>
                                <div className='row'>
                                    <div className='col l12'>
                                        <MultiselectForm {...members} />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <Integrations integrations={integrations} />
                    </div>
                </div>
            </div>
        );
    }
}

Manage.propTypes = {
    banner: React.PropTypes.string,
    integrations: React.PropTypes.array,
    members: React.PropTypes.object,
    kitUpdate: React.PropTypes.object,
}
