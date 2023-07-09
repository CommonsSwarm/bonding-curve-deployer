pragma solidity 0.6.2;

import "./BaseTemplate.sol";
import "./utils/SafeERC20.sol";

interface AugmentedBondingCurve {
    function initialize(
        TokenManager _tokenManager,
        address _formula,
        Vault _reserve,
        address _beneficiary,
        uint256 _buyFeePct,
        uint256 _sellFeePct
    ) external;

    function MANAGE_COLLATERAL_TOKEN_ROLE() external returns (bytes32);
    function addCollateralToken(
        address _collateral,
        uint256 _virtualSupply,
        uint256 _virtualBalance,
        uint32 _reserveRatio
    ) external;
}

contract PermeableTemplate is BaseTemplate, TokenCache {
    using SafeERC20 for IERC20;

    string private constant ERROR_EMPTY_HOLDERS = "PERMEABLE_EMPTY_HOLDERS";
    string private constant ERROR_BAD_HOLDERS_STAKES_LEN = "PERMEABLE_BAD_HOLDERS_STAKES_LEN";
    string private constant ERROR_BAD_VOTE_SETTINGS = "PERMEABLE_BAD_VOTE_SETTINGS";

    bool private constant TOKEN_TRANSFERABLE = true;
    uint8 private constant TOKEN_DECIMALS = uint8(18);
    uint256 private constant TOKEN_MAX_PER_ACCOUNT = uint256(0);
    uint64 private constant DEFAULT_FINANCE_PERIOD = uint64(30 days);

    uint256 private constant VIRTUAL_SUPPLY = uint256(0);
    uint256 private constant VIRTUAL_BALANCE = uint256(0);

    bytes32 internal constant ABC_APP_ID = 0x952fcbadf8d7288f1a8b47ed7ee931702318b527558093398674db0c93e3a75b;

    constructor(address _daoFactory, address _ens, address _miniMeFactory, address _aragonID)
        public
        BaseTemplate(
            DAOFactory(_daoFactory),
            ENS(_ens),
            MiniMeTokenFactory(_miniMeFactory),
            IFIFSResolvingRegistrar(_aragonID)
        )
    {
        _ensureAragonIdIsValid(address(_aragonID));
        _ensureMiniMeFactoryIsValid(address(_miniMeFactory));
    }

    /**
     * @dev Create a new MiniMe token and deploy a Permeable DAO. This function does not allow Payroll
     *      to be setup due to gas limits.
     * @param _tokenName String with the name for the token used by share holders in the organization
     * @param _tokenSymbol String with the symbol for the token used by share holders in the organization
     * @param _id String with the name for org, will assign `[id].aragonid.eth`
     * @param _holders Array of token holder addresses
     * @param _stakes Array of token stakes for holders (token has 18 decimals, multiply token amount `* 10^18`)
     * @param _votingSettings Array of [supportRequired, minAcceptanceQuorum, voteDuration] to set up the voting app of the organization
     * @param _fees Array of [buyFee, sellFee] to sep up the abc of the organization
     */
    function newTokenAndInstance(
        string calldata _tokenName,
        string calldata _tokenSymbol,
        string calldata _id,
        address[] calldata _holders,
        uint256[] calldata _stakes,
        uint64[3] calldata _votingSettings,
        uint256[2] calldata _fees, //0: buy, 1: sell
        address _collateralToken,
        uint32 _reserveRatio,
        uint256 _initialBalance
    ) external {
        newToken(_tokenName, _tokenSymbol);
        newInstance(_id, _holders, _stakes, _votingSettings, _fees, _collateralToken, _reserveRatio, _initialBalance);
    }

    /**
     * @dev Create a new MiniMe token and cache it for the user
     * @param _name String with the name for the token used by share holders in the organization
     * @param _symbol String with the symbol for the token used by share holders in the organization
     */
    function newToken(string memory _name, string memory _symbol) public returns (MiniMeToken) {
        MiniMeToken token = _createToken(_name, _symbol, TOKEN_DECIMALS);
        _cacheToken(token, msg.sender);
        return token;
    }

    /**
     * @dev Deploy a Permeable DAO using a previously cached MiniMe token
     * @param _id String with the name for org, will assign `[id].aragonid.eth`
     * @param _holders Array of token holder addresses
     * @param _stakes Array of token stakes for holders (token has 18 decimals, multiply token amount `* 10^18`)
     * @param _votingSettings Array of [supportRequired, minAcceptanceQuorum, voteDuration] to set up the voting app of the organization
     */
    function newInstance(
        string memory _id,
        address[] memory _holders,
        uint256[] memory _stakes,
        uint64[3] memory _votingSettings,
        uint256[2] memory _fees, //0: buy, 1: sell
        address _collateralToken,
        uint32 _reserveRatio,
        uint256 _initialBalance
    ) public returns (address) {
        _validateId(_id);
        _ensureSettings(_holders, _stakes, _votingSettings);

        (Kernel dao, ACL acl) = _createDAO();
        (Finance finance, Voting voting) = _setupApps(
            dao, acl, _holders, _stakes, _votingSettings, _fees, _collateralToken, _reserveRatio, _initialBalance
        );
        _transferCreatePaymentManagerFromTemplate(acl, finance, address(voting));
        _transferRootPermissionsFromTemplateAndFinalizeDAO(dao, address(voting));
        _registerID(_id, address(dao));

        return (address(dao));
    }

    function _setupApps(
        Kernel _dao,
        ACL _acl,
        address[] memory _holders,
        uint256[] memory _stakes,
        uint64[3] memory _votingSettings,
        uint256[2] memory _fees, //0: buy, 1: sell
        address _collateralToken,
        uint32 _reserveRatio,
        uint256 _initialBalance
    ) internal returns (Finance, Voting) {
        // 0: token, 1: agent, 2: finance, 3: token manager, 4: voting
        address[] memory apps = new address[](5);

        apps[0] = address(_popTokenCache(msg.sender));
        apps[1] = address(_installDefaultAgentApp(_dao));
        apps[2] = address(_installFinanceApp(_dao, Vault(apps[1]), DEFAULT_FINANCE_PERIOD));
        apps[3] =
            address(_installTokenManagerApp(_dao, MiniMeToken(apps[0]), TOKEN_TRANSFERABLE, TOKEN_MAX_PER_ACCOUNT));
        apps[4] = address(_installVotingApp(_dao, MiniMeToken(apps[0]), _votingSettings));

        _mintTokens(_acl, TokenManager(apps[3]), _holders, _stakes);
        _setupPermissions(_acl, Vault(apps[1]), Voting(apps[4]), Finance(apps[2]), TokenManager(apps[3]));

        _setupPermeableApps(
            _dao, _acl, TokenManager(apps[3]), apps[1], _fees, _collateralToken, _reserveRatio, apps[4], _initialBalance
        );
        _transferTokenManagerFromTemplate(_acl, TokenManager(apps[3]), apps[4]);

        return (Finance(apps[2]), Voting(apps[4]));
    }

    function _setupPermissions(
        ACL _acl,
        Vault _agentOrVault,
        Voting _voting,
        Finance _finance,
        TokenManager _tokenManager
    ) internal {
        _createAgentPermissions(_acl, Agent(address(_agentOrVault)), address(_voting), address(_voting));
        _createVaultPermissions(_acl, _agentOrVault, address(_finance), address(_voting));
        _createFinancePermissions(_acl, _finance, address(_voting), address(_voting));
        _createFinanceCreatePaymentsPermission(_acl, _finance, address(_voting), address(this));
        _createEvmScriptsRegistryPermissions(_acl, address(_voting), address(_voting));
        _createVotingPermissions(_acl, _voting, address(_voting), address(_tokenManager), address(_voting));
        _createTokenManagerPermissions(_acl, _tokenManager, address(_voting), address(this));
    }

    function _setupPermeableApps(
        Kernel _dao,
        ACL _acl,
        TokenManager _tokenManager,
        address _beneficiary,
        uint256[2] memory _fees, //0: buy, 1: sell
        address _collateralToken,
        uint32 _reserveRatio,
        address _vaultManager,
        uint256 _initialBalance
    ) internal {
        // install new permeable vault
        Vault _permeableVault = _installVaultApp(_dao);

        address _formula = 0xA4e28453b4F3fcB251EEbe1aC2798eEE55e2bE6a;
        AugmentedBondingCurve _augmentedBondingCurve =
            _installAugmentedBondingCurve(_dao, _tokenManager, _formula, _permeableVault, _beneficiary, _fees);
        _configureAugmentedBondingCurve(_augmentedBondingCurve, _acl, _collateralToken, _reserveRatio);

        // last thing to do
        _setupPermeablePermissions(_acl, _tokenManager, _permeableVault, _augmentedBondingCurve, _vaultManager);
    }

    function _receiveAmount(Vault _vault, uint256 _amount, address _collateralToken) internal {
        if (_amount == 0) {
            return;
        }
        if (_collateralToken == address(0)) {
            revert("ERROR_NATIVE_TOKEN_NOT_ACCEPTED");
        } else {
            require(
                IERC20(_collateralToken).transferFrom(msg.sender, address(_vault), _amount), "ERROR_TRANSFER_FAILED"
            );
        }
    }

    function _setupPermeablePermissions(
        ACL _acl,
        TokenManager _tokenManager,
        Vault _permeableVault,
        AugmentedBondingCurve _augmentedBondingCurve,
        address _vaultManager
    ) internal {
        _createVaultPermissions(_acl, _permeableVault, address(_augmentedBondingCurve), _vaultManager);
        _grantTokenManagerPermissions(_acl, _tokenManager, address(_augmentedBondingCurve));
    }

    function _transferTokenManagerFromTemplate(ACL _acl, TokenManager _tokenManager, address _manager) internal {
        _acl.setPermissionManager(_manager, address(_tokenManager), _tokenManager.BURN_ROLE());
        _acl.setPermissionManager(_manager, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    function _grantTokenManagerPermissions(ACL _acl, TokenManager _tokenManager, address _to) internal {
        _acl.grantPermission(_to, address(_tokenManager), _tokenManager.BURN_ROLE());
        _acl.grantPermission(_to, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    function _installAugmentedBondingCurve(
        Kernel _dao,
        TokenManager _tokenManager,
        address _formula,
        Vault _reserve,
        address _beneficiary,
        uint256[2] memory _fees //0: buy, 1: sell
    ) internal returns (AugmentedBondingCurve) {
        bytes memory initializeData = abi.encodeWithSelector(
            AugmentedBondingCurve(0).initialize.selector,
            _tokenManager,
            _formula,
            _reserve,
            _beneficiary,
            _fees[0],
            _fees[1]
        );
        return AugmentedBondingCurve(_installNonDefaultApp(_dao, ABC_APP_ID, initializeData));
    }

    function _configureAugmentedBondingCurve(
        AugmentedBondingCurve _augmentedBondingCurve,
        ACL _acl,
        address _collateralToken,
        uint32 _reserveRatio
    ) internal {
        // add permissions
        _acl.createPermission(
            address(this),
            address(_augmentedBondingCurve),
            _augmentedBondingCurve.MANAGE_COLLATERAL_TOKEN_ROLE(),
            address(this)
        );

        //function MANAGE_COLLATERAL_TOKEN_ROLE() external returns (bytes32);
        _augmentedBondingCurve.addCollateralToken(_collateralToken, VIRTUAL_SUPPLY, VIRTUAL_BALANCE, _reserveRatio);

        // remove permissions
        _acl.revokePermission(
            address(this), address(_augmentedBondingCurve), _augmentedBondingCurve.MANAGE_COLLATERAL_TOKEN_ROLE()
        );
        _acl.removePermissionManager(
            address(_augmentedBondingCurve), _augmentedBondingCurve.MANAGE_COLLATERAL_TOKEN_ROLE()
        );
    }

    function _ensureSettings(address[] memory _holders, uint256[] memory _stakes, uint64[3] memory _votingSettings)
        private
        pure
    {
        require(_holders.length > 0, ERROR_EMPTY_HOLDERS);
        require(_holders.length == _stakes.length, ERROR_BAD_HOLDERS_STAKES_LEN);
        require(_votingSettings.length == 3, ERROR_BAD_VOTE_SETTINGS);
    }
}
