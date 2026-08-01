import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Req,
  Res,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { OidcService } from './oidc.service';
import { OidcConfigService } from './oidc-config.service';
import { getErrorMessage } from './oidc.utils';
import { t } from '../../i18n/i18n.util';

@Controller('api/auth/oidc')
export class OidcController {
  constructor(
    private readonly oidcService: OidcService,
    private readonly oidcConfigService: OidcConfigService,
  ) {}

  /**
   * Get OIDC configuration (public endpoint)
   */
  @Get('config')
  async getConfig() {
    return this.oidcConfigService.getPublicConfig();
  }

  /**
   * Initiate OIDC login flow
   */
  @Get('initiate')
  async initiate(
    @Query('redirect') redirectUrl: string | undefined,
    @Res() res: Response,
  ) {
    try {
      const isEnabled = await this.oidcConfigService.isEnabled();
      if (!isEnabled) {
        throw new BadRequestException(t('oidc.notEnabled'));
      }

      const authUrl = await this.oidcService.getAuthorizationUrl(redirectUrl);
      return res.redirect(authUrl);
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }
      throw new InternalServerErrorException(t('oidc.initiateFailed'));
    }
  }

  /**
   * Handle OIDC callback - redirects to frontend with one-time exchange code
   */
  @Get('callback')
  async callback(
    @Req() req: Request,
    @Query('code') code: string | undefined,
    @Query('state') state: string | undefined,
    @Query('error') error: string | undefined,
    @Query('error_description') errorDescription: string | undefined,
    @Res() res: Response,
  ) {
    const frontendUrl = this.oidcConfigService.getAppUrl();

    if (error) {
      const errorMsg = errorDescription || error;
      return res.redirect(
        `${frontendUrl}/login?error=${encodeURIComponent(errorMsg)}`,
      );
    }

    if (!code || !state) {
      return res.redirect(
        `${frontendUrl}/login?error=${encodeURIComponent(t('oidc.missingCodeOrState'))}`,
      );
    }

    try {
      const callbackUrl = `${this.oidcConfigService.getAppUrl()}${req.originalUrl}`;
      const result = await this.oidcService.handleCallback(callbackUrl, state);
      const exchangeCode = this.oidcService.createExchangeCode(result);
      const redirectUrl = result.redirectUrl ?? '/';

      return res.redirect(
        `${frontendUrl}/login?code=${encodeURIComponent(exchangeCode)}&redirect=${encodeURIComponent(redirectUrl)}`,
      );
    } catch (error) {
      const errorMsg = getErrorMessage(error, t('oidc.callbackFailed'));
      return res.redirect(
        `${frontendUrl}/login?error=${encodeURIComponent(errorMsg)}`,
      );
    }
  }

  /**
   * Exchange a one-time code for access token and user
   */
  @Post('exchange')
  exchange(@Body('code') code: string | undefined) {
    if (!code || typeof code !== 'string') {
      throw new BadRequestException(t('oidc.missingCode'));
    }
    return this.oidcService.exchangeCode(code);
  }

  /**
   * Exchange mobile IdP access token for app tokens
   */
  @Post('exchange/mobile')
  async exchangeMobile(@Body('access_token') accessToken: string | undefined) {
    if (!accessToken || typeof accessToken !== 'string') {
      throw new BadRequestException(t('oidc.missingAccessToken'));
    }
    return this.oidcService.exchangeMobileToken(accessToken);
  }
}
