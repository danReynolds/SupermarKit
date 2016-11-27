const UserGroupTransfer = (props) => (
    <div className='user-group-transfer'>
        <Card title='Transfer Ownership'>
            <p>
                Select the new owner for this Kit. You will no
                longer have access to the Kit Settings.
            </p>
            <RadioPicker {...props} />
        </Card>
    </div>
);
