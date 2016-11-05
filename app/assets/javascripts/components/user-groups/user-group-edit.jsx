const { update } = React.addons;

const UserGroupEdit = React.createClass({
    mixins: [ModalContainer],

    propTypes: {
        url: React.PropTypes.string,
        userGroupIntegrations: React.PropTypes.object,
        userGroupSettings: React.PropTypes.object,
        userGroupBanner: React.PropTypes.object,
        modal: React.PropTypes.object,
        form: React.PropTypes.object,
    },

    getInitialState: function() {
        const {
            userGroupSettings,
            userGroupIntegrations,
        } = this.props;

        return {
            userGroupSettings,
            userGroupIntegrations,
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
            userGroupSettings: {
                name,
                description,
                default_group,
            },
            userGroupIntegrations: {
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
        if (default_group) {
            form.append('default_group', default_group);
        }
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

    onUserGroupSettingsChange: function(field, value) {
        this.setState(
            update(this.state, {
                userGroupSettings: {
                    [field]: { $set: value }
                },
            })
        );
    },

    onSlackMessageChange: function(index, field, value) {
        this.setState(
            update(this.state, {
                userGroupIntegrations: {
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
                userGroupIntegrations: {
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
            userGroupBanner,
            multiselect,
        } = this.props;
        const {
            modal: { selection },
            userGroupSettings,
            userGroupIntegrations,
        } = this.state;
        return (
            <div className='user-group-edit'>
                <div className='row'>
                    <div className='col l6'>
                        <UserGroupSettings
                            {...userGroupSettings}
                            onChange={this.onUserGroupSettingsChange}
                        />
                        <UserGroupBanner
                            {...userGroupBanner}
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
                        <UserGroupIntegrations
                            onSlackMessageChange={this.onSlackMessageChange}
                            onSlackFieldChange={this.onSlackFieldChange}
                            integrations={userGroupIntegrations}
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
