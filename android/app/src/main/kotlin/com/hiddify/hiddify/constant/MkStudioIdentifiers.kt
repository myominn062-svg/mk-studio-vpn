package com.hiddify.hiddify.constant

/**
 * MK Studio VPN identifiers — must not overlap with Hiddify (app.hiddify.com / com.hiddify.app).
 */
object MkStudioIdentifiers {
    const val PACKAGE_ID = "com.mkstudio.vpn"
    const val CHANNEL_PREFIX = PACKAGE_ID

    const val ACTION_SERVICE = "$PACKAGE_ID.SERVICE"
    const val ACTION_SERVICE_CLOSE = "$PACKAGE_ID.SERVICE_CLOSE"

    const val METHOD_CHANNEL = "$CHANNEL_PREFIX/method"
    const val PLATFORM_CHANNEL = "$CHANNEL_PREFIX/platform"
    const val SERVICE_STATUS_CHANNEL = "$CHANNEL_PREFIX/service.status"
    const val SERVICE_ALERTS_CHANNEL = "$CHANNEL_PREFIX/service.alerts"
    const val SERVICE_LOGS_CHANNEL = "$CHANNEL_PREFIX/service.logs"

    const val NOTIFICATION_CHANNEL_SERVICE = "$PACKAGE_ID.service"
    const val NOTIFICATION_ID_SERVICE = 41501

    const val VPN_SESSION_NAME = "MK Studio VPN"

    const val DEFAULT_GRPC_FRONT_PORT = 27178
    const val DEFAULT_GRPC_BACK_PORT = 27179
}
