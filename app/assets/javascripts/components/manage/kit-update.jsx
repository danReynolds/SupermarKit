const KitUpdate = ({
    badge,
    privacyDisplay,
    name,
    description,
    default_group,
    onFieldChange,
    onCheckboxChange,
}) => (
    <div className='card'>
        <div className='card-content'>
            <div className='row'>
                <div className={badge}>
                    {privacyDisplay}
                </div>
                <h3>Update Kit</h3>
                <div className='col l6'>
                    <div className='inputs'>
                        <label htmlFor='name'>Name</label>
                        <input
                            name='name'
                            id='name'
                            onChange={onFieldChange}
                            type='text'
                            value={name}
                        />
                        <label htmlFor='description'>Description</label>
                        <input
                            id='description'
                            name='description'
                            type='text'
                            onChange={onFieldChange}
                            value={description}
                        />
                    </div>
                </div>
                <div className='col l6'>
                    <p className='default-group'>
                        Set this Kit as your default to feature it in the menu.
                    </p>
                    <input
                        onChange={onCheckboxChange}
                        type='checkbox'
                        name='default_group'
                        id='default_group'
                        className='filled-in'
                        checked={default_group}
                    />
                    <label htmlFor='default_group'>
                        Default Kit
                    </label>
                </div>
            </div>
        </div>
    </div>
);

KitUpdate.propTypes = {
    badge: React.PropTypes.string,
    privacyDisplay: React.PropTypes.string,
    name: React.PropTypes.string,
    description: React.PropTypes.string,
    default_group: React.PropTypes.bool,
    onFieldChange: React.PropTypes.func,
    onCheckboxChange: React.PropTypes.func,
}
