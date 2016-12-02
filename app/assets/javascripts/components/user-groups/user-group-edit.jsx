const { update } = React.addons;

const UserGroupEdit = React.createClass({
    mixins: [ModalContainer],

    propTypes: {
        url: React.PropTypes.string,
        userGroupIntegrations: React.PropTypes.object,
        userGroupSettings: React.PropTypes.object,
        userGroupBanner: React.PropTypes.object,
        userGroupTransfer: React.PropTypes.object,
        modal: React.PropTypes.object,
        form: React.PropTypes.object,
    },

    getInitialState: function() {
        const {
            userGroupSettings,
            userGroupIntegrations,
            userGroupTransfer,
        } = this.props;

        return {
            userGroupSettings,
            userGroupIntegrations,
            userGroupTransfer,
        };
    },

    handleSave: function(modalSelection) {
        const {
            modal: { toggleModal },
            userGroupTransfer: { owner },
        } = this.state;
        let newOwner = owner;

        if (!modalSelection.find(selected => selected.id === owner)) {
            newOwner = modalSelection.length ? modalSelection[0].id : null
        }

        this.setState(
            update(this.state, {
                modal: {
                    selection: { $set: modalSelection }
                },
                userGroupTransfer: {
                    owner: { $set: newOwner }
                },
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
            userGroupTransfer: {
                owner,
            },
            modal: {
                selection
            },
        } = this.state;

        const form = new FormData();
        form.append('user_group[name]', name);
        form.append('user_group[owner_id]', owner);
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
            window.location = response.redirect_url;
        });
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

    onTransferOwnership: function(value) {
        this.setState(
            update(this.state, {
                userGroupTransfer: {
                    owner: { $set: value }
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
            userGroupTransfer: { owner },
            userGroupSettings,
            userGroupIntegrations,
        } = this.state;
        return (
            <div className='user-groups-edit'>
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
                        <UserGroupTransfer
                            onChange={this.onTransferOwnership}
                            selectedOption={owner}
                            options={selection}
                        />
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
