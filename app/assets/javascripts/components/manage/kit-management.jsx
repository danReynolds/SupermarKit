const { update } = React.addons;

const KitManagement = React.createClass({
    mixins: [ModalContainer],

    propTypes: {
        url: React.PropTypes.string,
        integrations: React.PropTypes.object,
        kitUpdate: React.PropTypes.object,
        kitBanner: React.PropTypes.object,
        modal: React.PropTypes.object,
        form: React.PropTypes.object,
    },

    getInitialState: function() {
        const {
            kitUpdate,
            integrations,
        } = this.props;

        return {
            kitUpdate,
            integrations,
        };
    },

    handleSave: function(modalSelection) {
        const { modal: { toggleModal } } = this.state;
        this.setState(
            update(this.state, {
                modal: {
                    selection: { $set: modalSelection }
                }
            }
        ), toggleModal);
    },

    onSubmit: function() {
        const { url } = this.props;
        const {
            bannerFile,
            kitUpdate: {
                name,
                description,
                default_group,
            },
            integrations: {
                slack: {
                    api_token,
                    message_types,
                }
            },
            modal: {
                selection
            },
        } = this.state;

        const form = new FormData();
        form.append('user_group[name]', name);
        form.append('user_group[description]', description);
        form.append('user_group[user_ids]', selection.map(selected => selected.id));
        form.append('default_group', default_group);
        if (bannerFile) {
            form.append('user_group[banner]', bannerFile);
        }
        form.append(
            'integrations',
            JSON.stringify({
                slack: {
                    api_token,
                    message_types: message_types.reduce((acc, message) => {
                        acc[message.id] = _.pick(message, ['format', 'enabled']);
                        return acc;
                    }, {}),
                }
            })
        );
        $.ajax({
            url,
            method: 'PATCH',
            contentType: false,
            processData: false,
            data: form,
        }).done(response => {
            window.location = url;
        }).error(response => {
            const { responseJSON: { errors } } = response;
            Materialize.toast(errors.join('\n'), 1000);
        })
    },

    onKitUpdateChange: function(field, value) {
        this.setState(
            update(this.state, {
                kitUpdate: {
                    [field]: { $set: value }
                },
            })
        );
    },

    onSlackMessageChange: function(index, field, value) {
        this.setState(
            update(this.state, {
                integrations: {
                    slack: {
                        message_types: {
                            [index]: {
                                [field]: { $set: value }
                            }
                        }
                    }
                }
            })
        )
    },

    onSlackFieldChange: function(field, value) {
        this.setState(
            update(this.state, {
                integrations: {
                    slack: {
                        [field]: { $set: value }
                    }
                }
            })
        )
    },

    onFileChange: function(e) {
        const { target: { files } } = e;
        this.setState({ bannerFile: files[0] });
    },

    render: function() {
        const {
            kitBanner,
            multiselect,
        } = this.props;
        const {
            modal: { selection },
            kitUpdate,
            integrations,
        } = this.state;
        return (
            <div className='kit-management'>
                <div className='row'>
                    <div className='col l6'>
                        <KitUpdate
                            {...kitUpdate}
                            onChange={this.onKitUpdateChange}
                        />
                        <KitBanner
                            {...kitBanner}
                            onFileChange={this.onFileChange}
                        />
                    </div>
                    <div className='col l6'>
                        <Card title='Kit Members'>
                            <Multiselect
                                {...multiselect}
                                expandable={false}
                                toggleModal={this.toggleModal}
                                selection={selection}
                            />
                        </Card>
                        <Integrations
                            onSlackMessageChange={this.onSlackMessageChange}
                            onSlackFieldChange={this.onSlackFieldChange}
                            integrations={integrations}
                        />
                    </div>
                </div>
                <div
                    onClick={this.onSubmit}
                    className='fixed-action-btn'>
                    <a className='btn-floating btn-large'>
                        <i className='large material-icons'>check</i>
                    </a>
                </div>
                <Modal
                    {...this.props.modal}
                    {...this.state.modal}
                />
            </div>
        );
    }
});
