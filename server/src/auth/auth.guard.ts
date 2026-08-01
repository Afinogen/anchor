import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ExtractJwt } from 'passport-jwt';
import { UserStatus } from '../generated/prisma/enums';
import { TokenResolverService } from './token-resolver.service';
import { AuthenticatedRequest } from './authenticated-request';
import { t } from '../i18n/i18n.util';

const extractBearerToken = ExtractJwt.fromAuthHeaderAsBearerToken();

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly tokenResolver: TokenResolverService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const token = extractBearerToken(request);

    if (!token) {
      throw new UnauthorizedException(t('auth.missingToken'));
    }

    const user = await this.tokenResolver.resolveUser(token);

    if (!user) {
      throw new UnauthorizedException(t('auth.invalidToken'));
    }

    if (user.status !== UserStatus.active) {
      throw new UnauthorizedException(t('auth.accountPendingApproval'));
    }

    request.user = user;
    return true;
  }
}
