const KitBanner = ({ banner, onFileChange }) => (
    <div className='card'>
        <div className='card-image'>
            <img src={banner} />
            <span className='card-title'>Kit banner</span>
        </div>
        <div className='card-content'>
            <p>Add a custom image to your Kit that will be displayed to all members.</p>
        </div>
        <div className='card-action'>
            <div className='input-field file-field'>
                <div className='btn'>
                    <span>File</span>
                    <input
                        name='banner'
                        type='file'
                        onChange={onFileChange}
                    />
                </div>
                <div className='file-path-wrapper'>
                    <input className='file-path validate' />
                </div>
            </div>
        </div>
    </div>
);

KitBanner.propTypes = {
    banner: React.PropTypes.string,
    onFileChange: React.PropTypes.func,
};
